/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        astrolabe: {
          teal: '#14302E', // Brand Primary Dark Teal
          tealLight: '#204d49',
          gold: '#C5A358', // Brand Accent Gold
          goldLight: '#d6be88',
          cream: '#FDFBF7', // Background cream
          beige: '#F5EFEB', // Secondary background
        }
      }
    },
  },
  plugins: [],
}
