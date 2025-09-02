let state = { netId: null };

window.addEventListener('message', (e) => {
  const data = e.data || {};
  const panel = document.getElementById('panel');
  if (data.action === 'open') {
    state.netId = data.netId;
    panel.style.left = `${data.x * 100}%`;
    panel.style.top = `${data.y * 100}%`;
    panel.classList.remove('hidden');
  } else if (data.action === 'hide') {
    panel.classList.add('hidden');
  } else if (data.action === 'position') {
    panel.style.left = `${data.x * 100}%`;
    panel.style.top = `${data.y * 100}%`;
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
  if (key === 'escape') {
    post('close', {});
  } else if (key === 'e') {
    post('kidnap', { netId: state.netId });
    post('close', {});
  } else if (key === 'x') {
    post('kneel', { netId: state.netId });
    post('close', {});
  } else if (key === 'g') {
    post('release', {});
    post('close', {});
  }
});
