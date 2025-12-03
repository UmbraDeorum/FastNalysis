# FastNalysis

```bash


  /$$$$$$$$                   /$$     /$$   /$$           /$$                     /$$
 | $$_____/                  | $$    | $$$ | $$          | $$                    |__/
 | $$    /$$$$$$   /$$$$$$$ /$$$$$$  | $$$$| $$  /$$$$$$ | $$ /$$   /$$  /$$$$$$$ /$$  /$$$$$$$
 | $$$$$|____  $$ /$$_____/|_  $$_/  | $$ $$ $$ |____  $$| $$| $$  | $$ /$$_____/| $$ /$$_____/
 | $$__/ /$$$$$$$|  $$$$$$   | $$    | $$  $$$$  /$$$$$$$| $$| $$  | $$|  $$$$$$ | $$|  $$$$$$
 | $$   /$$__  $$ \____  $$  | $$ /$$| $$\  $$$ /$$__  $$| $$| $$  | $$ \____  $$| $$ \____  $$
 | $$  |  $$$$$$$ /$$$$$$$/  |  $$$$/| $$ \  $$|  $$$$$$$| $$|  $$$$$$$ /$$$$$$$/| $$ /$$$$$$$/
 |__/   \_______/|_______/    \___/  |__/  \__/ \_______/|__/ \____  $$|_______/ |__/|_______/
  @UmbraDeorum                                                /$$  | $$
                                                             || $$$$$$/
                                                              \______/


//WARNING: Removing unreachable block (ram,0x0000116f)
//WARNING: Removing unreachable block (ram,0x000011a4)
//WARNING: Removing unreachable block (ram,0x000011b0)

```

<div align="center">

**A comprehensive binary analysis tool for CTF challenges and reverse engineering**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/yourusername/FastNalysis)

</div>

---

## 📋 Overview

FastNalysis is an automated binary analysis tool designed for CTF players and security researchers. It combines multiple analysis techniques into a single comprehensive report with intelligent highlighting of dangerous functions and security vulnerabilities.

### ✨ Key Features

- 🔍 **Comprehensive Analysis**: ELF headers, security features, dependencies, symbols, and more
- 🎨 **Smart Highlighting**: Automatically highlights dangerous functions and security issues in red
- 🧩 **Decompilation**: Integrated radare2/r2ghidra decompilation of user-defined functions
- 🛡️ **Security Analysis**: Checksec integration, stack canaries, PIE, RELRO, NX detection
- 🔬 **Dynamic Analysis**: System call tracing (strace), library call tracing (ltrace), memory leak detection (valgrind)
- 📊 **Disassembly**: Full objdump disassembly with section headers
- 🎯 **CTF-Focused**: Optimized for quick vulnerability identification in CTF challenges

---

## 🚀 Quick Start

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/FastNalysis.git
cd FastNalysis

# Make scripts executable
chmod +x FastNalysis.sh requirements.sh

# Install dependencies
./requirements.sh
```

### Usage
```bash
# Basic analysis
./FastNalysis.sh <binary_file>

# With command-line arguments (passed to binary for dynamic analysis)
./FastNalysis.sh <binary_file> arg1 arg2
```

### Example
```bash
./FastNalysis.sh ./vulnerable_binary
```

---

## 📦 Dependencies

FastNalysis requires the following tools:

### Core Tools
- `file` - File type identification
- `readelf` - ELF binary inspection
- `nm` - Symbol extraction
- `strings` - String extraction
- `objdump` - Disassembly
- `xxd` - Hex dump
- `ldd` - Shared library dependencies

### Dynamic Analysis Tools
- `strace` - System call tracing
- `ltrace` - Library call tracing
- `valgrind` - Memory leak detection

### Security & Decompilation
- `pwntools` - Security feature checking (checksec)
- `radare2` - Binary analysis framework
- `r2ghidra` - Ghidra decompiler plugin for radare2

All dependencies can be installed automatically using the included `requirements.sh` script.

---

## 🔧 What It Analyzes

### Static Analysis
1. **File Information**
   - File type detection
   - Architecture and binary format

2. **ELF Header**
   - Machine type, entry point, program/section headers
   - Binary characteristics

3. **Security Features**
   - Stack canaries
   - NX (No-Execute)
   - PIE (Position Independent Executable)
   - RELRO (Relocation Read-Only)
   - RWX segments

4. **Dependencies**
   - Shared libraries
   - Symbol versions

5. **Symbols**
   - Exported functions (color-coded by type)
   - Imported functions
   - Global variables

6. **Strings**
   - Embedded strings (length > 5)
   - Potential passwords, flags, or interesting data

7. **Section Headers**
   - Memory layout
   - Section permissions

8. **Disassembly**
   - Complete disassembly of executable sections
   - Dangerous function highlighting

9. **Decompilation**
   - User-defined functions only
   - Clean pseudocode output
   - Automatic function detection

### Dynamic Analysis
1. **System Calls**
   - Complete system call trace during execution
   - File operations, network activity, process management

2. **Library Calls**
   - Standard library function calls
   - Function arguments and return values

3. **Memory Analysis**
   - Memory leaks
   - Invalid reads/writes
   - Uninitialized values
   - Stack/heap corruption

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [radare2](https://github.com/radareorg/radare2) - Binary analysis framework
- [r2ghidra](https://github.com/radareorg/r2ghidra) - Ghidra decompiler integration
- [pwntools](https://github.com/Gallopsled/pwntools) - CTF framework
- [Valgrind](https://valgrind.org/) - Memory debugging tool

---

## 🐛 Known Issues

- macOS lacks strace/ltrace (use dtruss/dtrace as alternatives)
- Large binaries may produce very long output

---


<div align="center">

**⭐ Star this repository if you find it useful! ⭐**

Made with ❤️ for the CTF and security research community

</div>
