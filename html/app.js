let state = { netId: null, carrying: false };

window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'open') {
    state.netId = data.netId;
    state.carrying = !!data.carrying;
    document.getElementById('panel').classList.remove('hidden');
  }
});

const post = (name, body = {}) => {
  fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(body)
  }).then(() => {}).catch(()=>{});
};

document.getElementById('close').onclick = () => {
  document.getElementById('panel').classList.add('hidden');
  post('close', {});
};

document.getElementById('kidnap').onclick = () => {
  post('kidnap', { netId: state.netId });
  document.getElementById('panel').classList.add('hidden');
  post('close', {});
};

document.getElementById('release').onclick = () => {
  post('release', {});
  document.getElementById('panel').classList.add('hidden');
  post('close', {});
};

document.getElementById('putinveh').onclick = () => {
  post('putinveh', {});
  document.getElementById('panel').classList.add('hidden');
  post('close', {});
};

document.getElementById('takeoutveh').onclick = () => {
  post('takeoutveh', {});
  document.getElementById('panel').classList.add('hidden');
  post('close', {});
};

// ESC to close
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    document.getElementById('panel').classList.add('hidden');
    post('close', {});
  }
});
