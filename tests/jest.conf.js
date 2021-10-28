module.exports = {
  rootDir: "./",
  moduleDirectories: ["node_modules"],
  moduleFileExtensions: ["js", "ts", "json"],
  clearMocks: true,
  transform: {
    // '^.+\\.js$': 'babel-jest',
    "^.+(?:!\\.d|)\\.ts$": "ts-jest",
  },
  testRegex: "(/__tests__/.*|(\\.|/)spec)\\.(jsx?|tsx?)$",
  coverageDirectory: "./coverage",
  coveragePathIgnorePatterns: [
    "<rootDir>/coverage/",
    "<rootDir>/node_modules/",
  ],
  globals: {
    "ts-jest": {
      tsconfig: "./tsconfig.test.json",
    },
  },
};
