"""Network protocol handling for Slither.io"""

import socket
import struct
import threading
import queue
from typing import Callable, Optional

class SlitherSocket:
    """Handles binary TCP protocol for Slither.io servers"""
    
    def __init__(self):
        self.socket: Optional[socket.socket] = None
        self.connected = False
        self.receive_queue = queue.Queue()
        self.send_queue = queue.Queue()
        self.receive_thread = None
        self.header_size = 4  # 4-byte length prefix
        
        # Callbacks
        self.on_connect: Optional[Callable] = None
        self.on_disconnect: Optional[Callable] = None
        self.on_error: Optional[Callable] = None
        self.on_message: Optional[Callable] = None
    
    def connect(self, host: str, port: int) -> bool:
        """Connect to a Slither.io server"""
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((host, port))
            self.connected = True
            
            # Start receive thread
            self.receive_thread = threading.Thread(target=self._receive_loop, daemon=True)
            self.receive_thread.start()
            
            if self.on_connect:
                self.on_connect()
            
            return True
        except Exception as e:
            self.connected = False
            if self.on_error:
                self.on_error(str(e))
            return False
    
    def disconnect(self):
        """Disconnect from server"""
        self.connected = False
        if self.socket:
            try:
                self.socket.close()
            except:
                pass
        
        if self.on_disconnect:
            self.on_disconnect()
    
    def send_message(self, data: bytes):
        """Send a message to the server (with length prefix)"""
        if not self.connected:
            return
        
        try:
            # Add 4-byte length prefix (big-endian)
            length = len(data)
            packet = struct.pack('>I', length) + data
            self.socket.send(packet)
        except Exception as e:
            self.connected = False
            if self.on_error:
                self.on_error(str(e))
    
    def send_string(self, text: str):
        """Send a UTF-8 encoded string"""
        self.send_message(text.encode('utf-8'))
    
    def _receive_loop(self):
        """Continuously receive messages from server"""
        buffer = b''
        expected_length = None
        
        while self.connected:
            try:
                data = self.socket.recv(4096)
                if not data:
                    self.connected = False
                    if self.on_disconnect:
                        self.on_disconnect()
                    break
                
                buffer += data
                
                # Process complete messages
                while len(buffer) >= 4 and expected_length is None:
                    # Read length prefix
                    expected_length = struct.unpack('>I', buffer[:4])[0]
                    buffer = buffer[4:]
                
                if expected_length and len(buffer) >= expected_length:
                    # Extract message
                    message = buffer[:expected_length]
                    buffer = buffer[expected_length:]
                    expected_length = None
                    
                    # Call callback
                    if self.on_message:
                        self.on_message(message)
            
            except Exception as e:
                self.connected = False
                if self.on_error:
                    self.on_error(str(e))
                break
    
    def close(self):
        """Close the connection"""
        self.disconnect()
