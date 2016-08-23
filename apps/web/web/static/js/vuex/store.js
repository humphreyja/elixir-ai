import Vue from "vue"
import Vuex from "vuex"
import VueResource from "vue-resource"
Vue.use(VueResource)
Vue.use(Vuex)
const mutations = {
  LOAD_BRAIN_COMPONENTS (state, data) {
    state.brain_components = data
  },

  SHOW_BRAIN_COMPONENT (state, data) {
    state.current_brain_component = data
    state.action = 1 //show
    state.errors = null
  },

  NEW_BRAIN_COMPONENT (state) {
    state.current_brain_component = {}
    state.action = 2 //new
    state.errors = null
  },

  EDIT_BRAIN_COMPONENT (state, data) {
    state.current_brain_component = data
    state.action = 3 //edit
    state.errors = null
  },

  INDEX_BRAIN_COMPONENT (state, v) {
    v.$http.get('/api/components').then((response) => {
      state.brain_components = JSON.parse(response.body).data
      state.action = 0 //index
      state.errors = null
    }, (response) => {
      state.errors = JSON.parse(response.body).errors
    })
  },

  SUBMIT_BRAIN_COMPONENT (state, data, v, store) {
    state.current_brain_component = data
    if (state.current_brain_component == null) { return; }

    if (state.action == 2) {
      v.$http.post('/api/components', {component: state.current_brain_component}).then((response) => {
        store.dispatch("INDEX_BRAIN_COMPONENT", v)
        state.errors = null
      }, (response) => {
        state.errors = JSON.parse(response.body).errors
      })
    }else{
      v.$http.put('/api/components/' + state.current_brain_component.id, {component: state.current_brain_component}).then((response) => {
        store.dispatch("INDEX_BRAIN_COMPONENT", v)
        state.errors = null
      }, (response) => {
        state.errors = JSON.parse(response.body).errors
      })
    }
  }
}

const state = {
  brain_components: [],
  current_brain_component: {},
  action: 0,
  errors: null
}

const store = new Vuex.Store({
  mutations,
  state
})

export default store
