# Firecracker Quickstart

A simple guide to get up and running with Firecracker microVMs. This project provides scripts to set up and run Firecracker microVMs with minimal configuration.

## Prerequisites

- Ubuntu-based system with KVM support

## Quick Start

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/firecracker-quickstart.git
   cd firecracker-quickstart
   ```

2. Run the installation script:

   ```bash
   sudo make install
   ```

   This will install necessary packages including the Firecracker binary and its Linux kernel.

3. Build a base root file system:

   ```bash
   sudo make build
   ```

4. Run the microVM:

   ```bash
   sudo make run
   ```

5. Start Firecracker:

   ```bash
   sudo make start
   ```