# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react/README.md) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type aware lint rules:

- Configure the top-level `parserOptions` property like this:

```js
export default {
  // other rules...
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    project: ['./tsconfig.json', './tsconfig.node.json'],
    tsconfigRootDir: __dirname,
  },
}
```
> Test pour déclencher le déploiement Vercel

- Replace `plugin:@typescript-eslint/recommended` to `plugin:@typescript-eslint/recommended-type-checked` or `plugin:@typescript-eslint/strict-type-checked`
- Optionally add `plugin:@typescript-eslint/stylistic-type-checked`
- Install [eslint-plugin-react](https://github.com/jsx-eslint/eslint-plugin-react) and add `plugin:react/recommended` & `plugin:react/jsx-runtime` to the `extends` list
> Deuxième test pour déclencher déploiement
> Deuxième test pour déclencher déploiement
> Deuxième test pour déclencher déploiement
quatre test pour déclencher déploiement
Déploiement Vercel test
> teste
> test vert
> TESTE 10
Ajout test de déploiement Vercel

## Déploiement sur Vercel

Assurez-vous de définir les variables d'environnement suivantes dans les paramètres
du projet Vercel :

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Ces variables sont nécessaires pour que la connexion à Supabase fonctionne lors du
build et à l'exécution. Elles peuvent être configurées dans l'onglet **Environment
Variables** de votre projet Vercel.
