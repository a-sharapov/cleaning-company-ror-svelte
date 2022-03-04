  import { browser } from '$app/env'
  import { writable } from 'svelte/store'

export const prepareFormData = (data, object, defaultRemovedFields = null) => {
  Object.keys(object).map(key => {
    object[key] === "" && data.delete(key) 
  })

  if (defaultRemovedFields) {
    let defautls = defaultRemovedFields.split(',')
    defautls.map(key => {
      data.delete(key)
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

export const user = writable(getUserFromStorage())