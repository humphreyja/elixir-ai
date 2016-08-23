// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
//

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import 'phoenix_html'

import socket from './socket'

import Vue from "vue"
import VueResource from "vue-resource"
import store from "./vuex/store"
Vue.use(VueResource)

new Vue({
  el: "#root-components",
  data: {
    newBrainComp: {}
  },
  computed: {
    errorList() {
      let list = [];
      for(var error in this.errors) {
        list.push(error + " " + this.errors[error]);
      }
      return list
    }
  },
  ready() {
    this.loadData()
  },
  methods: {
  },
  store,
  vuex: {
    actions: {
      submitBrainComponent(store) {
        store.dispatch("SUBMIT_BRAIN_COMPONENT", this.newBrainComp, this, store)
      },
      showBrainComponent(store, comp) {
        store.dispatch("SHOW_BRAIN_COMPONENT", comp)
      },
      newBrainComponent(store) {
        store.dispatch("NEW_BRAIN_COMPONENT")
      },
      indexBrainComponent(store) {
        store.dispatch("INDEX_BRAIN_COMPONENT", this)
      },
      editBrainComponent(store, comp) {
        store.dispatch("EDIT_BRAIN_COMPONENT", comp)
        this.newBrainComp = this.current_brain_component
      },
      loadData(store) {
        store.dispatch("INDEX_BRAIN_COMPONENT", this)
      }
    },
    getters: {
      brain_components: state => state.brain_components,
      current_brain_component: state => state.current_brain_component,
      action: state => state.action,
      errors: state => state.errors
    }
  }
})
