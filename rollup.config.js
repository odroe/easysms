import typescript from 'rollup-plugin-typescript2';

export default {
    input: "src/index.ts",
    output: {
        file: "index.js",
        format: "cjs"
    },
    plugins: [
        typescript({
            tsconfig: "tsconfig.json",
            tsconfigOverride: {
                compilerOptions: {
                    declaration: false,
                    emitDeclarationOnly: false,
                }
            }
        }),
    ],
    external: ["@cloudbase/node-sdk/lib/cloudbase"],
};
