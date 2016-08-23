exports.config = {
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "scss/app.scss"
    },
    tempaltes: {
      joinTo: "js/app.js"
    }
  },
  conventions: {
    assets: /^(web\/static\/assets)/
  },
  paths: {
    watched: [
      "web/static",
      "test/static"
    ],
    public: "priv/static"
  },
  plugins: {
    babel: {
      ignore: [/web\/static\/vendor/]
    },
    sass: {
      mode: "native"
    }
  },
  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },
  npm: {
    enabled: true,
    whitelist: ["phoenix", "phoenix_html", "vue", "vuex", "vue-resource"]
  }
}
