import adapter from '@sveltejs/adapter-node'

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter(),
		target: '#app',
		methodOverride: {
      allowed: ['PUT', 'PATCH', 'DELETE']
    },
	},
}

export default config
