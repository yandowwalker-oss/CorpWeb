'use strict';

const nav = document.getElementById('main-nav');
const menu = document.querySelector('.menu-toggle');
const dialog = document.getElementById('project-dialog');
const form = document.getElementById('project-form');
const result = document.getElementById('brief-result');
const output = document.getElementById('brief');
const status = document.getElementById('status');
const projectType = document.getElementById('type');
const mobile = window.matchMedia('(max-width: 760px)');
let opener = null;

function closeMenu(restoreFocus = false) {
  nav.classList.remove('open');
  menu.setAttribute('aria-expanded', 'false');
  if (restoreFocus) menu.focus();
}

menu.addEventListener('click', () => {
  const open = menu.getAttribute('aria-expanded') !== 'true';
  menu.setAttribute('aria-expanded', String(open));
  nav.classList.toggle('open', open);
});

nav.querySelectorAll('a').forEach(link => link.addEventListener('click', () => closeMenu()));
document.addEventListener('keydown', event => {
  if (event.key === 'Escape' && menu.getAttribute('aria-expanded') === 'true') closeMenu(true);
});
document.addEventListener('click', event => {
  if (!event.target.closest('header')) closeMenu();
});
document.addEventListener('focusin', event => {
  if (!event.target.closest('header')) closeMenu();
});
mobile.addEventListener('change', () => {
  const focusWasInNav = nav.contains(document.activeElement);
  closeMenu(mobile.matches && focusWasInNav);
});

document.querySelectorAll('[data-contact], [data-type]').forEach(trigger => {
  trigger.addEventListener('click', () => {
    opener = trigger;
    closeMenu();
    if (trigger.dataset.type) {
      projectType.value = trigger.dataset.type;
      clearBrief();
    }
    dialog.showModal();
    document.body.classList.add('dialog-open');
    document.getElementById('dialog-title').focus();
    dialog.scrollTop = 0;
  });
});

document.querySelector('.close').addEventListener('click', () => dialog.close());
dialog.addEventListener('click', event => {
  const bounds = dialog.getBoundingClientRect();
  if (event.target === dialog && (event.clientX < bounds.left || event.clientX > bounds.right ||
    event.clientY < bounds.top || event.clientY > bounds.bottom)) dialog.close();
});
dialog.addEventListener('close', () => {
  document.body.classList.remove('dialog-open');
  // A mobile header trigger becomes hidden when its menu closes.
  const target = opener && opener.getClientRects().length ? opener : menu;
  target.focus({ preventScroll: true });
});
dialog.addEventListener('keydown', event => {
  if (event.key !== 'Tab') return;
  const controls = [...dialog.querySelectorAll('button, input, select, textarea')]
    .filter(element => !element.disabled && element.getClientRects().length);
  const first = controls[0];
  const last = controls[controls.length - 1];
  if (event.shiftKey && (document.activeElement === first || document.activeElement === document.getElementById('dialog-title'))) {
    event.preventDefault();
    last.focus();
  } else if (!event.shiftKey && document.activeElement === last) {
    event.preventDefault();
    first.focus();
  }
});

function clearBrief() {
  result.hidden = true;
  output.value = '';
  status.textContent = '';
}
form.addEventListener('input', clearBrief);
form.addEventListener('change', clearBrief);
// Native required validation permits whitespace; require meaningful text too.
['name', 'details'].forEach(id => {
  const field = document.getElementById(id);
  field.addEventListener('input', () => {
    field.setCustomValidity(field.value.trim() ? '' : 'Please enter more than spaces.');
  });
});
form.addEventListener('submit', event => {
  event.preventDefault();
  const fields = new FormData(form);
  output.value = `Project brief — Yandow Walker Construction Inc.\n\nName: ${fields.get('name').trim()}\nEmail: ${fields.get('email').trim()}\nProject: ${fields.get('type')}\nLocation: ${fields.get('location').trim() || 'To be discussed'}\n\n${fields.get('details').trim()}`;
  result.hidden = false;
  status.textContent = 'Brief ready to copy. Nothing has been sent.';
  output.focus();
});
document.getElementById('copy').addEventListener('click', async () => {
  const brief = output.value;
  if (!brief) return;
  try {
    await navigator.clipboard.writeText(brief);
    status.textContent = 'Brief copied to your clipboard. Nothing has been sent.';
  } catch {
    output.focus();
    output.select();
    status.textContent = 'Automatic copying is unavailable. The brief is selected: use Copy on your device, Ctrl+C, or Command+C. Nothing has been sent.';
  }
});
