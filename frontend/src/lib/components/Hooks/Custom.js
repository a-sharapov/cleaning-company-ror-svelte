  import { browser } from '$app/env'
  import { writable } from 'svelte/store'

export const prepareFormData = (data, object, defaultRemovedFields = null) => {
  Object.keys(object).map(key => {
    data[key] === "" && data.delete(key) 
  })

  if (defaultRemovedFields) {
    let defautls = defaultRemovedFields.split(',')
    defautls.map(key => {
      data.delete(key.split())
    })
  }

  return data
}

export const message = writable({
  content: null,
  type: "info",
})

export const getUserFromStorage = () => {
  let user
  browser ? user = window?.localStorage.getItem("user") ? window?.localStorage.getItem("user") : window?.sessionStorage.getItem("user") : user = null
  if (!!user) {
    return JSON.parse(user)
  } else {
    return false
  }
}

export const removeUserFromStorage = () => {
  if (browser) {
    window?.localStorage.getItem("user") && window?.localStorage.removeItem("user")
    window?.sessionStorage.removeItem("user")
  }
}

export const setUserInStorage = (user, remember) => {
  if (browser && user) {
    window?.sessionStorage.setItem("user", JSON.stringify(user))
    if (remember) {
      window?.localStorage.setItem("user", JSON.stringify(user))
    }
    return true
  }
  return false
}

export const remembered = () => {
  if (browser) 
  if (window?.localStorage.getItem("user")) {
    return true
  }
  return false
}

export const messageProcessor = (result) => {
  let assets = "",
      message = {
        type: "info",
        content: null,
      }

  if (result.error) {
    message.content = result.error
    message.type = "error"
    return message
  }
  if (result.assets) {
    if (result.assets === "retrieve") {
      message.content = result.content
      message.type = "retrieve"
      return message
    } else {
      Array.isArray(result.assets) ? assets = `<ul><li>${result.assets.join("</li><li>")}</li></ul>` : assets = `<p>${result.assets}</p>`
      message.type = "error"
      message.content = `<p>${result.message}:</p>` + assets
    }
  } else {
    message.type = "info"
    message.content = `<p>${result.message}</p>`
  }

  return message
}

export const user = writable(getUserFromStorage())