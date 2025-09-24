/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.haml',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        primary: '#3A6363',
      },
      maxWidth: {
        'container': '86rem',
      }
    },
  },
  plugins: [],
}
