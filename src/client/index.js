import Elm from './Main.elm'

const
  app_div = document.querySelector('#app_container')

if(app_div) {
  Elm.Main.embed(app_div)
}
