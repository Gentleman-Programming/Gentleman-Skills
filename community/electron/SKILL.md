---
name: electron
description: >
  Electron patterns for building cross-platform desktop applications.
  Trigger: When building desktop apps, working with Electron main/renderer processes, IPC communication, or native integrations.
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Load this skill when:
- Building cross-platform desktop applications
- Working with Electron's main and renderer processes
- Implementing IPC (Inter-Process Communication)
- Integrating native OS features (menus, notifications, file system)
- Setting up Electron with React, Vue, or other frameworks
- Configuring auto-updates and app distribution

## Critical Patterns

### Pattern 1: Project Structure

```
src/
├── main/                    # Main process (Node.js)
│   ├── index.ts            # Entry point
│   ├── ipc/                # IPC handlers
│   │   ├── handlers.ts
│   │   └── channels.ts     # Type-safe channel names
│   ├── services/           # Native services
│   │   ├── store.ts        # electron-store
│   │   └── updater.ts      # auto-updater
│   └── windows/            # Window management
│       └── main-window.ts
├── renderer/               # Renderer process (browser)
│   ├── src/
│   │   ├── App.tsx
│   │   ├── components/
│   │   └── hooks/
│   │       └── useIPC.ts   # IPC hooks
│   └── index.html
├── preload/                # Preload scripts
│   └── index.ts            # Expose safe APIs
└── shared/                 # Shared types
    └── types.ts
```

### Pattern 2: Secure IPC Communication

Always use contextBridge for secure communication:

```typescript
// preload/index.ts
import { contextBridge, ipcRenderer } from 'electron';
import type { IpcChannels } from '../shared/types';

// Type-safe exposed API
const electronAPI = {
  // One-way: renderer -> main
  send: <T extends keyof IpcChannels>(
    channel: T, 
    data: IpcChannels[T]['request']
  ) => {
    ipcRenderer.send(channel, data);
  },

  // Two-way: renderer -> main -> renderer
  invoke: <T extends keyof IpcChannels>(
    channel: T, 
    data: IpcChannels[T]['request']
  ): Promise<IpcChannels[T]['response']> => {
    return ipcRenderer.invoke(channel, data);
  },

  // Listen: main -> renderer
  on: <T extends keyof IpcChannels>(
    channel: T, 
    callback: (data: IpcChannels[T]['response']) => void
  ) => {
    const subscription = (_: Electron.IpcRendererEvent, data: IpcChannels[T]['response']) => {
      callback(data);
    };
    ipcRenderer.on(channel, subscription);
    return () => ipcRenderer.removeListener(channel, subscription);
  },
};

contextBridge.exposeInMainWorld('electron', electronAPI);
```

### Pattern 3: Type-Safe IPC Channels

Define all channels with request/response types:

```typescript
// shared/types.ts
export interface IpcChannels {
  'app:get-version': {
    request: void;
    response: string;
  };
  'file:read': {
    request: { path: string };
    response: { content: string } | { error: string };
  };
  'file:write': {
    request: { path: string; content: string };
    response: { success: boolean };
  };
  'dialog:open-file': {
    request: { filters?: Electron.FileFilter[] };
    response: string | null;
  };
  'store:get': {
    request: { key: string };
    response: unknown;
  };
  'store:set': {
    request: { key: string; value: unknown };
    response: void;
  };
}

// Extend Window interface for renderer
declare global {
  interface Window {
    electron: typeof electronAPI;
  }
}
```

## Code Examples

### Example 1: Main Process Setup

```typescript
// main/index.ts
import { app, BrowserWindow, ipcMain } from 'electron';
import path from 'path';
import { registerIpcHandlers } from './ipc/handlers';

let mainWindow: BrowserWindow | null = null;

async function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      preload: path.join(__dirname, '../preload/index.js'),
      contextIsolation: true,  // Required for security
      nodeIntegration: false,  // Required for security
      sandbox: true,           // Extra security
    },
    titleBarStyle: process.platform === 'darwin' ? 'hiddenInset' : 'default',
    trafficLightPosition: { x: 15, y: 10 },
  });

  // Register IPC handlers
  registerIpcHandlers();

  // Load the app
  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../renderer/index.html'));
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
```

### Example 2: IPC Handlers

```typescript
// main/ipc/handlers.ts
import { ipcMain, dialog, app } from 'electron';
import fs from 'fs/promises';
import Store from 'electron-store';

const store = new Store();

export function registerIpcHandlers() {
  // Get app version
  ipcMain.handle('app:get-version', () => {
    return app.getVersion();
  });

  // File operations
  ipcMain.handle('file:read', async (_, { path }) => {
    try {
      const content = await fs.readFile(path, 'utf-8');
      return { content };
    } catch (error) {
      return { error: (error as Error).message };
    }
  });

  ipcMain.handle('file:write', async (_, { path, content }) => {
    try {
      await fs.writeFile(path, content, 'utf-8');
      return { success: true };
    } catch {
      return { success: false };
    }
  });

  // Native dialogs
  ipcMain.handle('dialog:open-file', async (_, { filters }) => {
    const result = await dialog.showOpenDialog({
      properties: ['openFile'],
      filters: filters || [{ name: 'All Files', extensions: ['*'] }],
    });
    return result.canceled ? null : result.filePaths[0];
  });

  // Persistent storage
  ipcMain.handle('store:get', (_, { key }) => {
    return store.get(key);
  });

  ipcMain.handle('store:set', (_, { key, value }) => {
    store.set(key, value);
  });
}
```

### Example 3: React Hook for IPC

```typescript
// renderer/src/hooks/useIPC.ts
import { useCallback, useEffect, useState } from 'react';

export function useIPC<T>(
  channel: string,
  initialValue: T
): [T, boolean, Error | null] {
  const [data, setData] = useState<T>(initialValue);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let mounted = true;

    window.electron
      .invoke(channel, undefined)
      .then((result) => {
        if (mounted) {
          setData(result as T);
          setLoading(false);
        }
      })
      .catch((err) => {
        if (mounted) {
          setError(err);
          setLoading(false);
        }
      });

    return () => {
      mounted = false;
    };
  }, [channel]);

  return [data, loading, error];
}

// Hook for IPC subscriptions
export function useIPCListener<T>(
  channel: string,
  callback: (data: T) => void
) {
  useEffect(() => {
    const unsubscribe = window.electron.on(channel, callback);
    return unsubscribe;
  }, [channel, callback]);
}

// Hook for IPC mutations
export function useIPCMutation<TRequest, TResponse>(channel: string) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const mutate = useCallback(
    async (data: TRequest): Promise<TResponse | null> => {
      setLoading(true);
      setError(null);
      try {
        const result = await window.electron.invoke(channel, data);
        return result as TResponse;
      } catch (err) {
        setError(err as Error);
        return null;
      } finally {
        setLoading(false);
      }
    },
    [channel]
  );

  return { mutate, loading, error };
}
```

### Example 4: Auto-Updater Setup

```typescript
// main/services/updater.ts
import { autoUpdater } from 'electron-updater';
import { BrowserWindow } from 'electron';
import log from 'electron-log';

export function setupAutoUpdater(mainWindow: BrowserWindow) {
  autoUpdater.logger = log;
  autoUpdater.autoDownload = false;
  autoUpdater.autoInstallOnAppQuit = true;

  autoUpdater.on('checking-for-update', () => {
    mainWindow.webContents.send('updater:checking');
  });

  autoUpdater.on('update-available', (info) => {
    mainWindow.webContents.send('updater:available', info);
  });

  autoUpdater.on('update-not-available', () => {
    mainWindow.webContents.send('updater:not-available');
  });

  autoUpdater.on('download-progress', (progress) => {
    mainWindow.webContents.send('updater:progress', progress);
  });

  autoUpdater.on('update-downloaded', () => {
    mainWindow.webContents.send('updater:downloaded');
  });

  autoUpdater.on('error', (error) => {
    mainWindow.webContents.send('updater:error', error.message);
  });

  // Check for updates on startup (with delay)
  setTimeout(() => {
    autoUpdater.checkForUpdates();
  }, 5000);
}

// IPC handlers for updater
export function registerUpdaterHandlers() {
  ipcMain.handle('updater:check', () => autoUpdater.checkForUpdates());
  ipcMain.handle('updater:download', () => autoUpdater.downloadUpdate());
  ipcMain.handle('updater:install', () => autoUpdater.quitAndInstall());
}
```

### Example 5: Native Menu Setup

```typescript
// main/menu.ts
import { Menu, shell, app, BrowserWindow } from 'electron';

export function createMenu(mainWindow: BrowserWindow) {
  const isMac = process.platform === 'darwin';

  const template: Electron.MenuItemConstructorOptions[] = [
    ...(isMac
      ? [{
          label: app.name,
          submenu: [
            { role: 'about' as const },
            { type: 'separator' as const },
            { role: 'services' as const },
            { type: 'separator' as const },
            { role: 'hide' as const },
            { role: 'hideOthers' as const },
            { role: 'unhide' as const },
            { type: 'separator' as const },
            { role: 'quit' as const },
          ],
        }]
      : []),
    {
      label: 'File',
      submenu: [
        {
          label: 'Open File',
          accelerator: 'CmdOrCtrl+O',
          click: () => mainWindow.webContents.send('menu:open-file'),
        },
        {
          label: 'Save',
          accelerator: 'CmdOrCtrl+S',
          click: () => mainWindow.webContents.send('menu:save'),
        },
        { type: 'separator' },
        isMac ? { role: 'close' } : { role: 'quit' },
      ],
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' },
        { role: 'selectAll' },
      ],
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'togglefullscreen' },
      ],
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'Documentation',
          click: () => shell.openExternal('https://example.com/docs'),
        },
      ],
    },
  ];

  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}
```

## Anti-Patterns

### Don't: Enable nodeIntegration

```typescript
// ❌ DANGEROUS - Never do this
const win = new BrowserWindow({
  webPreferences: {
    nodeIntegration: true,    // Security vulnerability!
    contextIsolation: false,  // Security vulnerability!
  },
});

// ✅ Safe - Always use contextIsolation with preload
const win = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    contextIsolation: true,
    nodeIntegration: false,
    sandbox: true,
  },
});
```

### Don't: Use Remote Module

```typescript
// ❌ Bad - remote is deprecated and insecure
const { BrowserWindow } = require('@electron/remote');

// ✅ Good - Use IPC for all main process access
// In renderer:
const result = await window.electron.invoke('dialog:open-file', {});
```

### Don't: Expose Entire ipcRenderer

```typescript
// ❌ Bad - exposes everything
contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: ipcRenderer, // Never expose the entire module!
});

// ✅ Good - expose only specific, typed methods
contextBridge.exposeInMainWorld('electron', {
  invoke: (channel: string, data: unknown) => {
    const allowedChannels = ['app:get-version', 'file:read'];
    if (allowedChannels.includes(channel)) {
      return ipcRenderer.invoke(channel, data);
    }
    throw new Error(`Channel ${channel} not allowed`);
  },
});
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Create project | `npm create electron-vite@latest` |
| Main process file access | Use Node.js `fs` module in main |
| Renderer file access | IPC through preload |
| Persistent storage | `electron-store` in main process |
| Auto-updates | `electron-updater` |
| Native notifications | `new Notification()` in main |
| System tray | `Tray` class in main |
| Keyboard shortcuts | `globalShortcut.register()` |
| Deep linking | `app.setAsDefaultProtocolClient()` |
| Code signing | `electron-builder` config |

## Resources

- [Electron Documentation](https://www.electronjs.org/docs/latest)
- [Electron Forge](https://www.electronforge.io/)
- [electron-vite](https://electron-vite.org/)
- [electron-builder](https://www.electron.build/)
- [Electron Security Checklist](https://www.electronjs.org/docs/latest/tutorial/security)
