'use strict';

const nav = document.getElementById('main-nav');
const menu = document.querySelector('.menu-toggle');
const mobile = window.matchMedia('(max-width: 760px)');

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

const contactForm = document.getElementById('contact-form');
const projectDetails = document.getElementById('contact-project');

projectDetails.addEventListener('input', () => {
  projectDetails.setCustomValidity(projectDetails.value.trim() ? '' : 'Please describe your project.');
});

contactForm.addEventListener('submit', event => {
  event.preventDefault();
  if (!contactForm.reportValidity()) return;

  const fields = new FormData(contactForm);
  const body = [
    'Project inquiry — Yandow Walker Construction Inc.',
    '',
    `Name: ${fields.get('name').trim()}`,
    `Reply email: ${fields.get('email').trim()}`,
    '',
    'Project details:',
    fields.get('message').trim()
  ].join('\r\n');
  const subject = 'Website project inquiry';
  const mailto = `${contactForm.getAttribute('action')}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;

  openEmailDraft(mailto);
  document.getElementById('contact-status').textContent =
    'Your email app should open with your project inquiry. Review the draft and send it there. If no app opens, check that an email app is configured on your device. Nothing has been sent by this website.';
});

function openEmailDraft(mailto) {
  window.location.assign(mailto);
}
