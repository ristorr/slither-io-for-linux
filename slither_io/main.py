#!/usr/bin/env python3
"""
Slither.io for Linux - Main pygame client
"""

import pygame
import sys
import math
import argparse
from typing import Tuple
from slither_io.game import GameState, Snake, Food
from slither_io.network import SlitherSocket

class SlitherClient:
    """Main game client"""
    
    def __init__(self, width: int = 1024, height: int = 768, server: str = "localhost", port: int = 8000):
        pygame.init()
        
        self.screen = pygame.display.set_mode((width, height))
        pygame.display.set_caption("Slither.io for Linux")
        self.clock = pygame.time.Clock()
        self.running = True
        self.fps = 60
        
        self.width = width
        self.height = height
        
        # Game state
        self.game = GameState(map_width=width, map_height=height)
        self.game.create_player(1, "Player")
        
        # Network
        self.socket = SlitherSocket()
        self.socket.on_connect = self.on_connect
        self.socket.on_disconnect = self.on_disconnect
        self.socket.on_message = self.on_message
        
        self.server = server
        self.port = port
        self.connected = False
        
        # Add some test food
        for i in range(20):
            import random
            self.game.add_food(i, random.randint(0, width), random.randint(0, height))
        
        # Add some test snakes
        for i in range(2, 5):
            import random
            self.game.add_snake(i, f"Bot {i}", random.randint(100, width-100), random.randint(100, height-100), (random.randint(100, 255), random.randint(100, 255), random.randint(100, 255)))
    
    def on_connect(self):
        """Called when connected to server"""
        print("Connected to server!")
        self.connected = True
    
    def on_disconnect(self):
        """Called when disconnected from server"""
        print("Disconnected from server")
        self.connected = False
    
    def on_message(self, data: bytes):
        """Called when message received from server"""
        # TODO: Parse and handle server messages
        pass
    
    def handle_events(self):
        """Handle pygame events"""
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    self.running = False
    
    def update(self, dt: float):
        """Update game state"""
        # Get mouse position
        mouse_pos = pygame.mouse.get_pos()
        
        # Update game
        self.game.update(dt, mouse_pos[0], mouse_pos[1])
    
    def draw(self):
        """Draw game"""
        self.screen.fill((30, 30, 30))  # Dark background
        
        # Draw food
        for food in self.game.foods.values():
            pygame.draw.circle(self.screen, food.color, (int(food.x), int(food.y)), int(food.radius))
        
        # Draw snakes
        for snake in self.game.snakes.values():
            if not snake.dead:
                # Draw body
                for segment in snake.segments:
                    pygame.draw.circle(self.screen, snake.color, (int(segment.x), int(segment.y)), int(segment.radius))
                
                # Draw name
                if snake.name:
                    font = pygame.font.Font(None, 24)
                    text = font.render(snake.name, True, snake.color)
                    self.screen.blit(text, (int(snake.x) - 20, int(snake.y) - 30))
        
        # Draw score
        font = pygame.font.Font(None, 36)
        score_text = font.render(f"Score: {self.game.score}", True, (255, 255, 255))
        self.screen.blit(score_text, (10, 10))
        
        # Draw connection status
        status_text = "Connected" if self.connected else "Offline Mode"
        status_color = (0, 255, 0) if self.connected else (255, 0, 0)
        font = pygame.font.Font(None, 20)
        status = font.render(status_text, True, status_color)
        self.screen.blit(status, (self.width - 150, 10))
        
        pygame.display.flip()
    
    def run(self):
        """Main game loop"""
        print(f"Starting Slither.io for Linux")
        print(f"Attempting to connect to {self.server}:{self.port}...")
        
        # Try to connect (optional - game works offline too)
        self.socket.connect(self.server, self.port)
        
        while self.running:
            dt = self.clock.tick(self.fps) / 1000.0
            
            self.handle_events()
            self.update(dt)
            self.draw()
        
        self.socket.close()
        pygame.quit()
        print("Goodbye!")

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="Slither.io for Linux")
    parser.add_argument("--server", default="localhost", help="Server address (default: localhost)")
    parser.add_argument("--port", type=int, default=8000, help="Server port (default: 8000)")
    parser.add_argument("--width", type=int, default=1024, help="Window width (default: 1024)")
    parser.add_argument("--height", type=int, default=768, help="Window height (default: 768)")
    
    args = parser.parse_args()
    
    client = SlitherClient(
        width=args.width,
        height=args.height,
        server=args.server,
        port=args.port
    )
    client.run()

if __name__ == "__main__":
    main()
