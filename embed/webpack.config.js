const path = require('path');
const webpack = require('webpack');

module.exports = {
    mode: 'development',
    entry: { 'pyret': './src/pyret.ts', 'default-rpcs': './src/default-rpcs.ts' },
    module: {
        rules: [
            {
                test: /\.ts$/,
                use: 'ts-loader',
                exclude: /node_modules/
            }
        ]
    },
    resolve: {
        extensions: ['.ts', '.js'],
        fallback: {
            'fs': require.resolve('@zenfs/core'),
            'path': require.resolve('path-browserify')
        }
    },
    output: {
        filename: '[name].js',
        libraryTarget: 'module',
        path: path.resolve(__dirname, 'dist')
    },
    plugins: [
        new webpack.ProvidePlugin({
            // Make a global `process` variable that points to the `process` package,
            // Thanks to https://stackoverflow.com/a/65018686/14239942
            process: 'process/browser'
        })
    ],
    experiments: {
        outputModule: true,
    }
};