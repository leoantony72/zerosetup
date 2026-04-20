import 'package:flutter/material.dart';

class PersonaModel {
  final String title;
  final String description;
  final IconData icon;
  final List<String> stack;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String? decoratorHeroTag;

  const PersonaModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.stack,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.decoratorHeroTag,
  });
}

const mockPersonas = [
  PersonaModel(
    title: 'MERN Artisan',
    description: 'The complete JavaScript ecosystem for modern web applications. From database to DOM.',
    icon: Icons.code, // equivalent to code_blocks
    stack: ['MongoDB', 'Express.js', 'React 18', 'Node.js', 'TailwindCSS'],
    iconBackgroundColor: Color(0xFFB7EBCE), // secondaryContainer
    iconColor: Color(0xFF3C6C54), // onSecondaryContainer
  ),
  PersonaModel(
    title: 'Neural Architect',
    description: 'GPU-optimized environments for training, fine-tuning, and deploying large language models.',
    icon: Icons.psychology, // equivalent to neurology
    stack: ['PyTorch', 'CUDA 12', 'JupyterLab', 'HuggingFace', 'TensorFlow'],
    iconBackgroundColor: Color(0xFFE3EAE3), // surfaceContainerHigh
    iconColor: Color(0xFF161D19), // onSurface
  ),
  PersonaModel(
    title: 'Cloud Commander',
    description: 'Infrastructure as Code playground. Pre-configured with major cloud providers and container orchestration.',
    icon: Icons.hub, // equivalent to hub
    stack: ['Kubernetes', 'Terraform', 'Docker', 'AWS CLI', 'Helm'],
    iconBackgroundColor: Color(0x1A006C49), // surfaceTint with 10% opacity
    iconColor: Color(0xFF006C49), // surfaceTint
  ),
];
