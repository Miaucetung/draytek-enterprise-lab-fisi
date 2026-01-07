#!/bin/bash
set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   🚀 DrayTek Enterprise Lab - Full Setup                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }

if [[ !  -d ".  git" ]]; then
    echo "❌ Fehler: Nicht in einem Git-Repository!"
    exit 1
fi

log "Erstelle vollständige Ordnerstruktur..."
mkdir -p labs docs scripts config/examples diagrams assessments backups
success "Ordnerstruktur erstellt"
