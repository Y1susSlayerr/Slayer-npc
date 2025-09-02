let state = { netId: null, carrying: false };

window.addEventListener('message', (e) => {
  const data = e.data || {};
  const panel = document.getElementById('panel');
  if (data.action === 'open') {
    state.netId = data.netId;
    state.carrying = data.carrying;
    panel.style.left = `${data.x * 100}%`;
    panel.style.top = `${data.y * 100}%`;
    panel.classList.remove('hidden');
    panel.querySelectorAll('.option').forEach((btn) => {
      if (state.carrying && btn.dataset.action === 'kidnap') {
        btn.classList.add('hidden');
      } else {
        btn.classList.remove('hidden');
      }
    });
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

document.querySelectorAll('#panel .option').forEach((btn) => {
  btn.addEventListener('click', () => {
    const action = btn.dataset.action;
    if (action === 'release') {
      post(action, {});
    } else {
      post(action, { netId: state.netId });
    }
    post('close', {});
  });
});

document.addEventListener('keydown', (e) => {
  const key = e.key.toLowerCase();
  if (key === 'escape') {
    post('close', {});
  } else if (key === 'e' && !state.carrying) {
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
