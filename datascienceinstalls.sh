#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to install NVIDIA drivers
install_nvidia_drivers() {
    echo "Installing NVIDIA drivers..."
    sudo apt-get update || { echo "Failed to update package list"; exit 1; }
    sudo apt-get install -y nvidia-driver-510-server || { echo "Failed to install NVIDIA drivers"; exit 1; }
    sudo reboot
}

# Function to install Anaconda
install_anaconda() {
    echo "Installing Anaconda..."
    wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh || { echo "Failed to download Anaconda"; exit 1; }
    sh Anaconda3-2022.10-Linux-x86_64.sh -b || { echo "Failed to install Anaconda"; exit 1; }
    eval "$($HOME/anaconda3/bin/conda shell.bash hook)" || { echo "Failed to initialize Anaconda"; exit 1; }
}

# Function to set up PyTorch with GPU support
setup_pytorch() {
    echo "Setting up PyTorch with GPU support..."
    conda create --name=pytorch python=3.9 -y || { echo "Failed to create PyTorch conda environment"; exit 1; }
    conda activate pytorch || { echo "Failed to activate PyTorch conda environment"; exit 1; }
    conda install pytorch torchvision torchaudio pytorch-cuda=11.6 -c pytorch -c nvidia -y || { echo "Failed to install PyTorch"; exit 1; }
    python3 -c "import torch; assert torch.cuda.is_available(), 'CUDA not available for PyTorch'" || { echo "PyTorch setup failed"; exit 1; }
}

# Function to set up TensorFlow with GPU support
setup_tensorflow() {
    echo "Setting up TensorFlow with GPU support..."
    conda create --name=tf python=3.9 -y || { echo "Failed to create TensorFlow conda environment"; exit 1; }
    conda activate tf || { echo "Failed to activate TensorFlow conda environment"; exit 1; }
    conda install -c conda-forge cudatoolkit=11.2.2 cudnn=8.1.0 -y || { echo "Failed to install CUDA toolkit and cuDNN"; exit 1; }
    mkdir -p $CONDA_PREFIX/etc/conda/activate.d || { echo "Failed to create conda activation directory"; exit 1; }
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_PREFIX/lib/' > $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh || { echo "Failed to set environment variables"; exit 1; }
    conda deactivate
    conda activate tf || { echo "Failed to reactivate TensorFlow conda environment"; exit 1; }
    python3 -m pip install tensorflow==2.10 || { echo "Failed to install TensorFlow"; exit 1; }
    python3 -c "import tensorflow as tf; assert len(tf.config.list_physical_devices('GPU')) > 0, 'No GPU available for TensorFlow'" || { echo "TensorFlow setup failed"; exit 1; }
}

# Install NVIDIA drivers
install_nvidia_drivers

# Install Anaconda
install_anaconda

# Set up PyTorch
setup_pytorch

# Set up TensorFlow
setup_tensorflow

echo "Installation complete. Both TensorFlow and PyTorch are set up with GPU support."
