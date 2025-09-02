let state = { netId: null, carrying: false };

window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'open') {
    state.netId = data.netId;
    state.carrying = !!data.carrying;
    document.getElementById('panel').classList.remove('hidden');
  } else if (data.action === 'hide') {
    document.getElementById('panel').classList.add('hidden');
  }
});

const post = (name, body = {}) => {
  fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(body)
  }).catch(()=>{});
};

document.addEventListener('keydown', (e) => {
  const key = e.key.toLowerCase();
  if (document.getElementById('panel').classList.contains('hidden')) return;
  if (key === 'y') {
    post('kidnap', { netId: state.netId });
    post('close', {});
  } else if (key === 'u') {
    post('kneel', { netId: state.netId });
    post('close', {});
  } else if (key === 'o') {
    post('release', {});
    post('close', {});
  } else if (key === 'escape') {
    post('close', {});
  }
});
