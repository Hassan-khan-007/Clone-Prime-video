# 🚀 Prime Video Clone - Application & CI Repository

This repository contains the application source code, custom `Dockerfile`, and the declarative `Jenkinsfile` for the end-to-end local **DevSecOps & GitOps pipeline**. It serves as the primary code repository where continuous integration, security gates, container building, and vulnerability scanning take place.

---

## 🏗️ Architectural Role (CI Phase)
When a developer pushes code to this repository, the automated **Jenkins** server orchestrates the following pipeline stages:
1. **Workspace Checkout & Cleaning:** Clears residual files and pulls the latest source code.
2. **Static Application Security Testing (SAST):** Evaluates code quality, code smells, and security bugs via **SonarQube** with mandatory Quality Gates.
3. **Software Composition Analysis (SCA):** Scans third-party project dependencies for known CVEs using **OWASP Dependency-Check** (with local cache optimization `-n`).
4. **Container Build (DooD):** Builds the application image using Docker-outside-of-Docker socket binding (`/var/run/docker.sock`).
5. **Container Vulnerability Analysis:** Scans the newly built image using **Trivy** to catch high and critical OS-level vulnerabilities before registry upload.
6. **Registry Push:** Securely pushes the versioned container image to **Docker Hub**.
7. **GitOps CD Bridge:** Dynamically updates the image tag inside the separate CD repository (`Clone-Prime-video-CD`) using a secure `sed` command and pushes the commit automatically.

---

## 🛠️ Tech Stack
* **Language/Framework:** Node.js / React (Prime Video Clone implementation)
* **CI/CD Orchestration:** Jenkins (Port `9080`)
* **Security Scanners:** SonarQube, OWASP Dependency-Check, Trivy
* **Containerization:** Docker Desktop, Docker Hub (`hassankhan786/prime-video-clone`)

---

## 📄 Jenkinsfile Overview
The pipeline is fully automated via the root-level declarative `Jenkinsfile`. Credentials such as GitHub Personal Access Tokens (PAT) and Docker Hub credentials are securely fetched from Jenkins credential manager (`github-credentials`, `dockerhub`).

---

## 🔗 Related Repository
* **GitOps CD Repository:** [Clone-Prime-video-CD](https://github.com/Hassan-khan-007/Clone-Prime-video-CD) *(Houses the Kubernetes manifests synchronized by Argo CD)*
