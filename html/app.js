let state = { netId: null };

window.addEventListener('message', (e) => {
  const data = e.data || {};
  const panel = document.getElementById('panel');
  if (data.action === 'open') {
    state.netId = data.netId;
    panel.classList.remove('hidden');
  } else if (data.action === 'hide') {
    panel.classList.add('hidden');
  }
});

const post = (name, body = {}) => {
  fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(body)
  }).catch(()=>{});
};

document.getElementById('kidnapBtn').addEventListener('click', () => {
  post('kidnap', { netId: state.netId });
  post('close', {});
});

document.getElementById('kneelBtn').addEventListener('click', () => {
  post('kneel', { netId: state.netId });
  post('close', {});
});

document.getElementById('releaseBtn').addEventListener('click', () => {
  post('release', {});
  post('close', {});
});

document.getElementById('closeBtn').addEventListener('click', () => {
  post('close', {});
});

document.addEventListener('keydown', (e) => {
  if (e.key.toLowerCase() === 'escape') {
    post('close', {});
  }
});
