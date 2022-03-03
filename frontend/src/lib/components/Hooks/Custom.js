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