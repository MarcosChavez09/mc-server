#!/usr/bin/env python3
"""
Minecraft Server Connectivity Test Script

This script tests the connectivity to the Minecraft server using the mcstatus library.
It verifies that the server is running and accessible on the specified port.

Usage:
    python test_server.py [server_ip] [port]

Example:
    python test_server.py localhost 8888
    python test_server.py 192.168.1.100 8888
"""

import sys
import socket
from mcstatus import JavaServer
import time

def test_port_connectivity(host, port, timeout=5):
    """Test basic port connectivity"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((host, port))
        sock.close()
        return result == 0
    except Exception as e:
        print(f"Error testing port connectivity: {e}")
        return False

def test_minecraft_server(host, port):
    """Test Minecraft server using mcstatus library"""
    try:
        server = JavaServer.lookup(f"{host}:{port}")
        
        # Test server status
        print(f"Testing Minecraft server at {host}:{port}...")
        
        # Get server status
        status = server.status()
        
        print("✅ Server is online!")
        print(f"   Version: {status.version.name}")
        print(f"   Players: {status.players.online}/{status.players.max}")
        print(f"   Description: {status.description}")
        print(f"   Latency: {status.latency:.2f}ms")
        
        # Show player list if any players are online
        if status.players.online > 0 and status.players.sample:
            print("   Online players:")
            for player in status.players.sample:
                print(f"     - {player.name}")
        
        return True
        
    except Exception as e:
        print(f"❌ Failed to connect to Minecraft server: {e}")
        return False

def main():
    # Default values
    host = "localhost"
    port = 8888
    
    # Parse command line arguments
    if len(sys.argv) > 1:
        host = sys.argv[1]
    if len(sys.argv) > 2:
        try:
            port = int(sys.argv[2])
        except ValueError:
            print("Error: Port must be a number")
            sys.exit(1)
    
    print(f"Testing Minecraft server connectivity...")
    print(f"Host: {host}")
    print(f"Port: {port}")
    print("-" * 50)
    
    # Test basic port connectivity first
    print("1. Testing port connectivity...")
    if test_port_connectivity(host, port):
        print("✅ Port is accessible")
    else:
        print("❌ Port is not accessible")
        print("   Make sure the server is running and the port is open")
        sys.exit(1)
    
    # Test Minecraft server
    print("\n2. Testing Minecraft server...")
    if test_minecraft_server(host, port):
        print("\n🎉 All tests passed! Server is ready for connections.")
        sys.exit(0)
    else:
        print("\n💥 Server test failed!")
        print("   Make sure the Minecraft server is fully started")
        sys.exit(1)

if __name__ == "__main__":
    main() 