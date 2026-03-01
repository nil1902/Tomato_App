const { createClient } = require('@insforge/sdk');

// Mock fetch to see the exact URL
global.fetch = async (url, options) => {
  console.log("==FETCH INTERCEPT==");
  console.log("URL:", url);
  Object.keys(options).forEach(k => {
      if(k !== 'body') console.log(k, options[k]);
  });
  return {
    ok: true,
    status: 200,
    json: async () => ({}),
    text: async () => ""
  };
};

const client = createClient({baseUrl: 'https://nukpc39r.ap-southeast.insforge.app', anonKey: 'test'});
client.storage.from('admin_bucket').upload('test.png', 'test_data').then(res => console.log("Done", res)).catch(e => console.error(e));
