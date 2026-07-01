#!/usr/bin/env python3
"""
Slither.io for Linux - Tkinter version (no external dependencies)
Run with: python3 slither_io/main_tkinter.py
"""

import tkinter as tk
import math
import random
from slither_io.game import GameState, Snake

class SlitherClientTkinter:
    """Game client using Tkinter (built-in Python library)"""
    
    def __init__(self, width: int = 1024, height: int = 768):
        self.root = tk.Tk()
        self.root.title("Slither.io for Linux")
        self.root.geometry(f"{width}x{height}")
        
        self.canvas = tk.Canvas(self.root, width=width, height=height, bg='#1e1e1e')
        self.canvas.pack()
        
        self.width = width
        self.height = height
        
        # Game state
        self.game = GameState(map_width=width, map_height=height)
        self.game.create_player(1, "You")
        
        # Add test food
        for i in range(30):
            self.game.add_food(i, random.randint(0, width), random.randint(0, height))
        
        # Add test snakes (AI opponents)
        for i in range(2, 6):
            self.game.add_snake(i, f"Bot {i}", random.randint(100, width-100), random.randint(100, height-100), 
                              (random.randint(100, 255), random.randint(100, 255), random.randint(100, 255)))
        
        # Mouse tracking
        self.mouse_x = width // 2
        self.mouse_y = height // 2
        self.canvas.bind("<Motion>", self.on_mouse_move)
        self.root.bind("<Escape>", lambda e: self.root.quit())
        
        # Game loop
        self.running = True
        self.update_game()
    
    def on_mouse_move(self, event):
        """Track mouse position"""
        self.mouse_x = event.x
        self.mouse_y = event.y
    
    def update_game(self):
        """Update and draw game"""
        if not self.running:
            return
        
        # Update game state
        self.game.update(0.016, self.mouse_x, self.mouse_y)
        
        # Clear canvas
        self.canvas.delete("all")
        
        # Draw background
        self.canvas.create_rectangle(0, 0, self.width, self.height, fill='#1e1e1e', outline='#1e1e1e')
        
        # Draw food
        for food in self.game.foods.values():
            x, y = int(food.x), int(food.y)
            r = int(food.radius)
            self.canvas.create_oval(x-r, y-r, x+r, y+r, fill=self._color_to_hex(food.color), outline=self._color_to_hex(food.color))
        
        # Draw snakes
        for snake in self.game.snakes.values():
            if not snake.dead:
                color_hex = self._color_to_hex(snake.color)
                
                # Draw body segments
                for segment in snake.segments:
                    x, y = int(segment.x), int(segment.y)
                    r = int(segment.radius)
                    self.canvas.create_oval(x-r, y-r, x+r, y+r, fill=color_hex, outline=color_hex)
                
                # Draw name
                if snake.name and snake.segments:
                    head_x, head_y = int(snake.segments[0].x), int(snake.segments[0].y)
                    self.canvas.create_text(head_x, head_y - 25, text=snake.name, fill=color_hex, font=("Arial", 10, "bold"))
        
        # Draw score
        self.canvas.create_text(20, 20, text=f"Score: {self.game.score}", fill="#ffffff", font=("Arial", 16, "bold"), anchor="nw")
        self.canvas.create_text(20, 50, text=f"Length: {self.game.player.length if self.game.player else 0}", fill="#00ff00", font=("Arial", 12), anchor="nw")
        
        # Draw status
        status_text = "OFFLINE MODE" if not self.game.player.dead else "DEAD"
        status_color = "#00ff00" if not self.game.player.dead else "#ff0000"
        self.canvas.create_text(self.width - 20, 20, text=status_text, fill=status_color, font=("Arial", 12, "bold"), anchor="ne")
        
        # Draw instructions
        self.canvas.create_text(self.width // 2, self.height - 20, text="Move mouse to control • ESC to quit", 
                               fill="#888888", font=("Arial", 10), anchor="s")
        
        # Schedule next update (60 FPS)
        self.root.after(16, self.update_game)
    
    def _color_to_hex(self, rgb_tuple):
        """Convert RGB tuple to hex color"""
        return '#{:02x}{:02x}{:02x}'.format(rgb_tuple[0], rgb_tuple[1], rgb_tuple[2])
    
    def run(self):
        """Run the game"""
        print("🎮 Slither.io for Linux - Tkinter Edition")
        print("Move your mouse to control the snake")
        print("Eat red food to grow")
        print("Avoid other snakes or crash!")
        print("Press ESC to quit\n")
        
        try:
            self.root.mainloop()
        except KeyboardInterrupt:
            pass
        
        print("Thanks for playing!")

def main():
    """Entry point"""
    client = SlitherClientTkinter(1024, 768)
    client.run()

if __name__ == "__main__":
    main()
