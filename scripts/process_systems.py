#!/usr/bin/env python3
"""
System Name Resolution Script for InsightFinder Terraform Module

This script processes InsightFinder system data and resolves system names to system IDs.
It handles complex nested JSON structures that are difficult to parse with bash/jq.

Usage:
    python3 process_systems.py <json_file> <target_systems_json>

Args:
    json_file: Path to the JSON file containing system data from InsightFinder API
    target_systems_json: JSON string containing array of target system names

Returns:
    Comma-separated list of resolved system IDs

Exit codes:
    0: Success - all systems resolved
    1: Failure - one or more systems not found
"""

import json
import sys
import os

def load_system_data(json_file):
    """Load and parse the system data from JSON file."""
    try:
        with open(json_file, 'r') as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"❌ Error loading system data: {e}", file=sys.stderr)
        sys.exit(1)

def parse_target_systems(target_systems_json):
    """Parse the target system names from JSON string."""
    try:
        return json.loads(target_systems_json)
    except json.JSONDecodeError as e:
        print(f"❌ Error parsing target systems: {e}", file=sys.stderr)
        sys.exit(1)

def search_systems_in_array(systems_array, target_name, array_type="system"):
    """Search for a system in the given array (own or shared systems)."""
    for system_json in systems_array:
        try:
            system = json.loads(system_json)
            if system.get('systemDisplayName') == target_name:
                system_id = system.get('systemKey', {}).get('systemName')
                if system_id:
                    print(f"✅ Found '{target_name}' in {array_type} systems: {system_id}", file=sys.stderr)
                    return system_id
        except (json.JSONDecodeError, Exception):
            # JSON parsing failed, try regex extraction for malformed JSON
            import re
            display_name_match = re.search(r'"systemDisplayName":"([^"]+)"', system_json)
            if display_name_match and display_name_match.group(1) == target_name:
                system_name_match = re.search(r'"systemName":"([^"]+)"', system_json)
                if system_name_match:
                    system_id = system_name_match.group(1)
                    print(f"✅ Found '{target_name}' in {array_type} systems (regex): {system_id}", file=sys.stderr)
                    return system_id
            continue
    return None

def show_available_systems(data, max_display=10):
    """Display available systems for debugging purposes."""
    import re
    
    print('Available own systems:', file=sys.stderr)
    count = 0
    for system_json in data.get('ownSystemArr', []):
        try:
            system = json.loads(system_json)
            name = system.get('systemDisplayName', 'N/A')
            print(f'  - {name}', file=sys.stderr)
            count += 1
            if count >= max_display:
                break
        except:
            # Try regex extraction for malformed JSON
            display_name_match = re.search(r'"systemDisplayName":"([^"]+)"', system_json)
            if display_name_match:
                name = display_name_match.group(1)
                print(f'  - {name}', file=sys.stderr)
                count += 1
                if count >= max_display:
                    break
    
    print(f'Available shared systems (first {max_display}):', file=sys.stderr)
    count = 0
    for system_json in data.get('shareSystemArr', []):
        try:
            system = json.loads(system_json)
            name = system.get('systemDisplayName', 'N/A')
            print(f'  - {name}', file=sys.stderr)
            count += 1
            if count >= max_display:
                break
        except:
            # Try regex extraction for malformed JSON
            display_name_match = re.search(r'"systemDisplayName":"([^"]+)"', system_json)
            if display_name_match:
                name = display_name_match.group(1)
                print(f'  - {name}', file=sys.stderr)
                count += 1
                if count >= max_display:
                    break

def resolve_system_names(data, target_systems):
    """Resolve target system names to system IDs."""
    print(f'Target systems: {target_systems}', file=sys.stderr)
    
    found_ids = []
    missing_systems = []
    
    for target_name in target_systems:
        print(f'Searching for: {target_name}', file=sys.stderr)
        found = False
        
        # Search in own systems first
        system_id = search_systems_in_array(
            data.get('ownSystemArr', []), 
            target_name, 
            "own"
        )
        
        if system_id:
            found_ids.append(system_id)
            found = True
        else:
            # If not found in own systems, search in shared systems
            system_id = search_systems_in_array(
                data.get('shareSystemArr', []), 
                target_name, 
                "shared"
            )
            
            if system_id:
                found_ids.append(system_id)
                found = True
        
        if not found:
            print(f'❌ System "{target_name}" not found', file=sys.stderr)
            missing_systems.append(target_name)
    
    return found_ids, missing_systems

def main():
    """Main function to process system name resolution."""
    if len(sys.argv) != 3:
        print("Usage: python3 process_systems.py <json_file> <target_systems_json>", file=sys.stderr)
        sys.exit(1)
    
    json_file = sys.argv[1]
    target_systems_json = sys.argv[2]
    
    # Validate input file exists
    if not os.path.exists(json_file):
        print(f"❌ JSON file not found: {json_file}", file=sys.stderr)
        sys.exit(1)
    
    # Load and parse data
    data = load_system_data(json_file)
    target_systems = parse_target_systems(target_systems_json)
    
    # Resolve system names to IDs
    found_ids, missing_systems = resolve_system_names(data, target_systems)
    
    # Handle results
    if missing_systems:
        print(f"❌ Failed to resolve {len(missing_systems)} system(s): {missing_systems}", file=sys.stderr)
        show_available_systems(data)
        sys.exit(1)
    else:
        print(f"✅ Successfully resolved all {len(found_ids)} system name(s)", file=sys.stderr)
        # Output the comma-separated list of system IDs to stdout
        print(','.join(found_ids))
        sys.exit(0)

if __name__ == "__main__":
    main()