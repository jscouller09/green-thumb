import { stopEverything } from '@rails/ujs';

const onClick = (event) => {
  const link = event.currentTarget;

  const onConfirmClick = (event) => {
    link.removeEventListener('click', onClick);
    link.click();
    link.addEventListener("click", onClick);
    confirmButton.removeEventListener('click', onConfirmClick);
  }

  const onCancelClick = (event) => {
    confirmButton.removeEventListener('click', onConfirmClick);
    cancelButton.removeEventListener('click', onCancelClick);
  }

  const confirmText = document.getElementById('conf-modal-body');
  confirmText.innerText = link.dataset.modalConfirm;

  event.preventDefault();
  stopEverything(event);
  $('#conf-modal').modal('show')

  const confirmButton = document.querySelector('#confirm-confirm-modal')
  confirmButton.addEventListener('click', onConfirmClick);

  const cancelButton = document.querySelector('#cancel-confirm-modal')
  cancelButton.addEventListener('click', onCancelClick);
}


const links = document.querySelectorAll("a[data-modal-confirm]")
links.forEach( (link) => {
  link.addEventListener("click", onClick);
});
