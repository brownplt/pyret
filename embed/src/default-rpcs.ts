import * as myfs from 'fs';
const path = require('path');


/**
 * This is a simple in-memory RPC implementation for file operations.
 * It expects to have ZenFS be used as the browser-based fallback in webpack for
 * `fs`.
 * 
 * It allows errors to propagate to the caller; the RPC infrastructure should
 * forward these on.
 */
export const rpc = {
    'fs': {
        'readFile': async (path: string) => {
            return myfs.readFileSync(path);
        },
        'writeFile': async (path: string, data: string | Buffer) => {
            myfs.writeFileSync(path, data);
        },
        'exists': async (path: string) => {
            return myfs.existsSync(path);
        },
        'stat': async (p: string) => {
            const stat = await myfs.promises.stat(p);
            return {
                mtime: stat.mtimeMs,
                ctime: stat.ctimeMs,
                size: stat.size,
                native: stat
            };
        },
        'createDir': async (p: string) => {
            await myfs.promises.mkdir(p, { recursive: true });
        }
    },
    'path': {
        'join': (...paths: string[]) => {
            return path.join(...paths);
        },
        'resolve': (p: string) => {
            return path.resolve(p);
        },
        'basename': (p: string) => {
            return path.basename(p);
        },
        'dirname': (p: string) => {
            return path.dirname(p);
        },
        'extname': (p: string) => {
            return path.extname(p);
        },
        'relative': (from: string, to: string) => {
            return path.relative(from, to);
        },
        'is-absolute': (p: string) => {
            return path.isAbsolute(p);
        }
    }

};
