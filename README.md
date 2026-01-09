# Solar System NodeJS Application

A simple HTML+MongoDB+NodeJS project to display Solar System and it's planets.

---
## Requirements

For development, you will only need Node.js and NPM installed in your environement.

### Node
- #### Node installation on Windows

  Just go on [official Node.js website](https://nodejs.org/) and download the installer.
Also, be sure to have `git` available in your PATH, `npm` might need it (You can find git [here](https://git-scm.com/)).

- #### Node installation on Ubuntu

  You can install nodejs and npm easily with apt install, just run the following commands.

      $ sudo apt install nodejs
      $ sudo apt install npm

- #### Other Operating Systems
  You can find more information about the installation on the [official Node.js website](https://nodejs.org/) and the [official NPM website](https://npmjs.org/).

If the installation was successful, you should be able to run the following command.

    $ node --version
    v8.11.3

    $ npm --version
    6.1.0

---
## Install Dependencies from `package.json`
    $ npm install

## Run Unit Testing
    $ npm test

## Run Code Coverage
    $ npm run coverage

## Run Application
    $ npm start

## Access Application on Browser
    http://localhost:3000/

---
## 🚀 Preview Environments

This repository is configured with **automatic preview environments** for Pull Requests!

### How it works:

1. **Create a PR** → GitHub Actions automatically deploys your code
2. **Get a dedicated environment** → Each PR gets its own isolated Kubernetes namespace
3. **Test your changes** → Access via port-forward before merging
4. **Automatic cleanup** → Environment is deleted when PR is closed

### Access your preview:

When you create a PR, GitHub Actions will comment with instructions like:

```bash
kubectl port-forward -n solar-system-pr-{number} svc/solar-system-pr-{number} 3000:3000
```

Then open: http://localhost:3000

### Documentation:

- 📖 [Quick Start](./QUICKSTART.md) - Get started in 5 minutes
- 📚 [Complete Guide](./PREVIEW_ENVIRONMENTS.md) - Full documentation
- ✅ [Setup Checklist](./SETUP_CHECKLIST.md) - Step-by-step validation
- 🧪 [Personal Testing](./PERSONAL_GITHUB_TEST.md) - Test in your personal GitHub

---
**Powered by Kubernetes + Helm + GitHub Actions** 🎉

