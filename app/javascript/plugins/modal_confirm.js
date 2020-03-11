import { stopEverything } from '@rails/ujs';

const onClick = (event) => {
  const link = event.currentTarget;
  // check if there is a parent modal this modal was called from
  const modal = document.getElementById('error-modal');
  if (modal) {
    // send parent modal to the back
    modal.style.zIndex = -1;
  }

  const onConfirmClick = (event) => {
    link.removeEventListener('click', onClick);
    link.click();
    link.addEventListener("click", onClick);
    confirmButton.removeEventListener('click', onConfirmClick);
  }

  const onCancelClick = (event) => {
    confirmButton.removeEventListener('click', onConfirmClick);
    cancelButton.removeEventListener('click', onCancelClick);
    if (modal) {
      // restore parent modal position
      modal.style.zIndex = "";
    }
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


export { onClick };
