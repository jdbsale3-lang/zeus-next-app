// Dev-only stand-in for the workerd `cloudflare:workers` module.
// The deployed Worker runtime provides the REAL module; local `vite dev` does
// not, so the vite config aliases this shim in when command !== "build".
// Accessing any binding here fails loudly — the sandbox path is the
// VITE_ZEUS_MOCK=1 mock, which never touches bindings. If you hit this error,
// you are on a code path that genuinely needs a deployed environment.

export const env: unknown = new Proxy(
  {},
  {
    get(_target, prop) {
      throw new Error(
        `cloudflare:workers binding "${String(prop)}" is only available on the deployed Worker. ` +
          "Run the sandbox with VITE_ZEUS_MOCK=1 (mocked server functions) or deploy.",
      );
    },
  },
);