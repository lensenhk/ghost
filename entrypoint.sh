mkdir "$GHOST_INSTALL/current/adapters/storage"
cd $GHOST_INSTALL/content/adapters/storage
git clone https://github.com/robincsamuel/ghost-google-drive.git
npm install