# React Security Guidance

## General Posture

Security is not a post-processing step. Review every change against this checklist before declaring a task complete. Flag any concern found — even if the task did not explicitly mention security.

Note: React applications run in the browser. Many security concerns (SQL injection, server-side auth) belong to the backend. Frontend security focuses on XSS, data exposure, insecure storage, and safe rendering.

## XSS (Cross-Site Scripting)

React escapes JSX content by default — `{userContent}` is safe:

```tsx
// Safe — React escapes this automatically:
<p>{userProvidedText}</p>

// DANGEROUS — bypasses React's escaping:
<div dangerouslySetInnerHTML={{ __html: userProvidedHtml }} />
```

Rules for `dangerouslySetInnerHTML`:
- Never use it with user-controlled content without sanitization.
- If HTML rendering is genuinely required, sanitize with DOMPurify first:
  ```tsx
  import DOMPurify from 'dompurify';
  <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(richText) }} />
  ```
- Prefer Markdown renderers that sanitize output over raw HTML injection.

## Sensitive Data in State

- Never store authentication tokens, passwords, or PII in component state that is logged to the browser console.
- Never include sensitive values in error messages rendered to the DOM.
- Be careful with what ends up in Redux DevTools or React Query devtools in production builds.

## Environment Variables and Secrets

React environment variables prefixed with `REACT_APP_` (CRA) or `VITE_` (Vite) are bundled into the client JavaScript. They are **not secret**:

```
VITE_API_URL=https://api.example.com      ← safe, not a secret
VITE_STRIPE_PUBLIC_KEY=pk_live_...        ← safe, designed to be public
VITE_DB_PASSWORD=hunter2                  ← NEVER do this
```

- Never expose private keys, secret tokens, or database credentials in frontend environment variables.
- API calls that require secret keys must go through a backend proxy — never from the browser directly.

## Local Storage and Session Storage

- Do not store authentication tokens or sensitive data in `localStorage` or `sessionStorage` — they are accessible to any JavaScript on the page (XSS attack surface).
- Prefer `HttpOnly` cookies for authentication tokens (set by the server, inaccessible to JavaScript).
- If you must use storage for non-sensitive caching (UI state, theme preferences), that is acceptable.

## Third-Party Scripts

- Avoid dynamically loading third-party scripts from user-controlled URLs.
- Audit all third-party dependencies for malicious or vulnerable packages (`npm audit`).
- Use Subresource Integrity (SRI) attributes for CDN-hosted scripts if applicable.

## Open Redirect

- When redirecting based on a URL parameter (e.g., `?returnUrl=/dashboard`), validate that the destination is within your application:
  ```tsx
  function safeRedirect(returnUrl: string): string {
    try {
      const url = new URL(returnUrl, window.location.origin);
      if (url.origin !== window.location.origin) {
        return '/'; // reject external redirect
      }
      return url.pathname + url.search;
    } catch {
      return '/';
    }
  }
  ```

## CSRF

For React SPAs that authenticate via JWT in headers (Bearer tokens), CSRF is not a concern for API calls. If your app uses cookies for authentication, ensure the backend enforces CSRF protection (SameSite cookies or CSRF tokens).

## Content Security Policy

Content Security Policy (CSP) is set by the server, but the frontend must comply:
- Avoid inline `<script>` and `<style>` tags — use external files.
- Avoid `eval()`, `new Function()`, and dynamic code execution.
- If using `styled-components` or CSS-in-JS, consult their CSP documentation for nonce handling.

## Input Sanitization

- Validate and sanitize user inputs before using them in URLs, file paths, or API calls.
- Use URL encoding when embedding user values in URLs: `encodeURIComponent(value)`.
- Do not construct URLs by string concatenation with user input.

## Dependency Security

- Run `npm audit` or `pnpm audit` in CI. Resolve critical and high severity vulnerabilities.
- Keep React, React DOM, and key libraries up to date.
- Review the permissions and size of new npm packages before adding them.
- Use `npm audit --production` to focus on runtime (not devDependency) vulnerabilities.

## Security Review Checklist

Before completing any task involving user input, dynamic rendering, authentication, or external data:

- [ ] No `dangerouslySetInnerHTML` with unescaped user content
- [ ] DOMPurify or equivalent used if HTML rendering is genuinely required
- [ ] No secrets or private keys in environment variables bundled to the client
- [ ] No authentication tokens stored in `localStorage` or `sessionStorage`
- [ ] `returnUrl` or redirect parameters are validated to stay within the application origin
- [ ] No dynamic script loading from user-controlled URLs
- [ ] `npm audit` reports no critical vulnerabilities in production dependencies
- [ ] No `eval()` or dynamic code execution with user-controlled values
- [ ] Error messages do not expose stack traces or sensitive internal data in the UI
