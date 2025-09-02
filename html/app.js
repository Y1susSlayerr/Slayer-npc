let state = { netId: null, carrying: false };

window.addEventListener('message', (e) => {
  const data = e.data || {};
  const panel = document.getElementById('panel');
  const carry = document.getElementById('carry');
  if (data.action === 'open') {
    state.netId = data.netId;
    state.carrying = data.carrying;
    panel.style.left = `${data.x * 100}%`;
    panel.style.top = `${data.y * 100}%`;
    panel.classList.remove('hidden');
    panel.querySelectorAll('.option').forEach((btn) => {
      const action = btn.dataset.action;
      if (state.carrying) {
        if (action === 'kidnap') {
          btn.classList.add('hidden');
        } else {
          btn.classList.remove('hidden');
        }
      } else {
        if (action === 'kidnap') {
          btn.classList.remove('hidden');
        } else {
          btn.classList.add('hidden');
        }
      }
    });
  } else if (data.action === 'hide') {
    panel.classList.add('hidden');
  } else if (data.action === 'position') {
    panel.style.left = `${data.x * 100}%`;
    panel.style.top = `${data.y * 100}%`;
  } else if (data.action === 'carrying') {
    state.carrying = data.show;
    if (data.show) {
      carry.classList.remove('hidden');
    } else {
      carry.classList.add('hidden');
    }
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
  } else if (key === 'g' && state.carrying) {
    post('kneel', { netId: state.netId });
    post('close', {});
  } else if (key === 'x' && state.carrying) {
    post('release', {});
    post('close', {});
  }
});
