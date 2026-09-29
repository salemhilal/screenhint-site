module.exports = {
    purge: [],
    darkMode: 'media', // or 'media' or 'class'
    theme: {
      extend: {
        colors: {
          // ScreenHint brand color, pulled from mockup G4 (#FDC331 mustard/gold)
          mustard: {
            50: '#FFFBF0',
            100: '#FFF5DC',
            200: '#FEE9B3',
            300: '#FEDA81',
            400: '#FDCE58',
            500: '#FDC331',
            600: '#F7B202',
            700: '#C58E02',
            800: '#926901',
            900: '#654901',
          },
        },
        letterSpacing: {
          logo: '-1px',
        },
      },
    },
    variants: {},
    plugins: [],
  }
