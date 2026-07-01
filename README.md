# Slither.io for Linux

A native Linux port of the popular Slither.io game, built from reverse-engineering the original Android/AIR game.

## Features

- ✅ Native Linux desktop application
- ✅ Snake movement and controls
- ✅ Food collection
- ✅ Multiplayer gameplay (when connected to server)
- ✅ Score tracking
- ✅ Offline mode (practice mode)

## Installation

### Requirements
- Linux (Ubuntu 20.04+, Fedora 32+, etc.)
- Python 3.6+
- pip (Python package manager)

### Install from Source

```bash
# Clone or navigate to the repository
cd slither-io-for-linux

# Install the package
pip install -e .

# Or install dependencies manually
pip install pygame numpy
```

### Install System Dependencies (Linux)

**Ubuntu/Debian:**
```bash
sudo apt install python3 python3-pip python3-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev
```

**Fedora/RHEL:**
```bash
sudo dnf install python3 python3-pip SDL2-devel SDL2_image-devel SDL2_mixer-devel SDL2_ttf-devel
```

**Arch Linux:**
```bash
sudo pacman -S python python-pip sdl2 sdl2_image sdl2_mixer sdl2_ttf
```

## Usage

### Quick Start (Offline Mode)
```bash
slither-io
```

### Connect to Server
```bash
slither-io --server slither.io --port 8000
```

### Custom Window Size
```bash
slither-io --width 1920 --height 1080
```

### From Source
```bash
python -m slither_io.main
```

## Controls

- **Mouse Movement**: Control your snake direction
- **ESC**: Quit game
- **Left Click**: (Future) Speed boost

## Project Structure

```
slither-io-for-linux/
├── slither_io/
│   ├── __init__.py          # Package initialization
│   ├── main.py              # Main pygame client
│   ├── game.py              # Game logic (snakes, food, collisions)
│   ├── network.py           # Network protocol handler
│   └── assets/              # Game assets (images, sounds)
├── output_scripts/          # Decompiled ActionScript code (reference)
├── output_images/           # Extracted game textures
├── output_sounds/           # Extracted game audio
├── setup.py                 # Installation script
└── README.md               # This file
```

## Development

### Running in Development Mode

```bash
python -m slither_io.main --server localhost --port 8000
```

### Running Tests (Future)

```bash
pytest tests/
```

## Architecture

### Network Protocol
- Binary TCP protocol with 4-byte length prefixes
- Packet-based communication
- See `slither_io/network.py` for details

### Game Objects
- **Snake**: Player-controlled or AI snakes with segmented bodies
- **Food**: Collectible items that increase snake length
- **GameState**: Central game state management

### Graphics
- Pygame 2D rendering engine
- Extracted textures from original game

## Troubleshooting

### "pygame not found"
```bash
pip install pygame
```

### "Connection refused"
- Game is designed to work offline
- Server connection is optional
- Press ESC to close if it hangs connecting

### "Low performance"
- Try reducing window size: `--width 800 --height 600`
- Reduce FPS by editing `main.py` (line with `self.fps = 60`)

## Contributing

Found a bug or want to add a feature?
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Legal Notice

This project is for educational purposes - it demonstrates reverse engineering and game development techniques using decompiled code from the original Slither.io game. The original game is owned by Steve Howse.

## License

GPL v3 - See LICENSE file

## Roadmap

- [ ] Connect to live Slither.io servers
- [ ] Implement game audio
- [ ] Add skins and cosmetics
- [ ] Create local multiplayer server
- [ ] Package as .deb, .rpm, .AppImage
- [ ] Controller support
- [ ] Replay system

## Support

Having issues? 
1. Check the [README](README.md)
2. Look at [existing issues](https://github.com/ristorr/slither-io-for-linux/issues)
3. Create a new issue with details

---

**Made with ❤️ by ristorr**

Play Slither.io natively on your Linux desktop!
