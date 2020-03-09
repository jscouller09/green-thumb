import interact from 'interactjs';


const add_plant_to_plot=(plant, plants_container, mm_per_pixel) => {
  // generate a plant div with a nested thumbnail image
  const plant_div = document.createElement('div');
  const thumbnail = document.createElement('div');
  const plant_border = document.createElement('div');

  // set plant div id and css properties
  plant_div.classList.add('plot-plant');
  plant_div.setAttribute('data-id', plant.id);
  plant_div.removeAttribute('hidden');
  plant_div.style.width = `${plant.radius_mm * 2 / mm_per_pixel}px`;
  plant_div.style.width = `${plant.radius_mm * 2 / mm_per_pixel}px`;
  plant_div.style.height = `${plant.radius_mm * 2 / mm_per_pixel}px`;

  // style plant border
  plant_border.classList.add('plot-plant-border');

  // style thumbnail image
  thumbnail.classList.add('plot-plant-thumbnail');
  // thumbnail.style.backgroundImage = `url("https://res.cloudinary.com/dm6mj1qp1/image/upload/v1583325509/${plant.photo_url}")`;
  thumbnail.style.backgroundImage = `url("${plant.icon}")`;

  // insert the thumbnail/border into the plant div
  plant_border.appendChild(thumbnail);
  plant_div.appendChild(plant_border);

  // insert the plant div into the plot container
  plants_container.appendChild(plant_div);

  return plant_div;
}

const init_ineractjs=(plant, element, mm_per_pixel, grid_size) => {
  let x = plant.x * grid_size;
  let y = plant.y * grid_size;
  element.style.transform = 'translate(' + x + 'px, ' + y + 'px)';

  interact(element)
    .draggable({
      modifiers: [
        interact.modifiers.snap({
          targets: [
            interact.createSnapGrid({ x: grid_size, y: grid_size })
          ],
          range: Infinity,
          relativePoints: [ { x: 0, y: 0 } ]
        }),
        interact.modifiers.restrict({
          restriction: element.parentNode,
          elementRect: { top: 0, left: 0, bottom: 1, right: 1 },
          endOnly: true
        })
      ],
      inertia: true,
      listeners: {
        end: (event) => {
          //console.log(event.currentTarget.dataset.id, plant.x, plant.y, x, y);
          // send x and y with fetch
          const csrfToken = document.querySelector('meta[name="csrf-token"]').content
          const url = `/plants/${element.dataset.id}`
          fetch(url, { method: "PATCH",
                       headers: { 'Content-Type': 'application/json',
                                  'x-csrf-token': csrfToken },
                       body: JSON.stringify(plant),
                      })
            .then(res => res.json())
            .then((data) => {
              if (data.accepted) {
                // if response ok, keep updated plant x/y
                console.log(`plant ${plant.id} moved to x:${plant.x} y:${plant.y}`);
              } else {
                // move it back to where it was
                plant.x = data.x
                plant.y = data.y
                x = data.x * grid_size;
                y = data.y * grid_size;
                event.target.style.transform = 'translate(' + x + 'px, ' + y + 'px)'
                console.log(data.errors.base[0]);
                // modal
                const modal_btn = document.getElementById('error-modal-button');
                const modal_body = document.getElementById('error-modal-body');
                modal_body.innerHTML = data.errors.base[0];
                modal_btn.click();
              }
            })
        }
      }
    })
    .on('dragmove', function (event) {
      // update plant position (in number of grid cells, not pixels)
      plant.x += Math.round((event.dx / grid_size))
      plant.y += Math.round((event.dy / grid_size))
      // make sure current position matches what is in plant
      x = plant.x * grid_size;
      y = plant.y * grid_size;
      event.target.style.transform = 'translate(' + x + 'px, ' + y + 'px)'
    })
}



const init_plant_dragging=() => {
  // check if we have a plant plot on the page
  const plants_container = document.getElementById('plot-container');
  if (plants_container) {
    // first destroy any children already in the plot
    plants_container.innerHTML = "";
    // determine grid spacing based of viewport size and plot size
    const intViewportHeight = window.innerHeight;
    const intViewportWidth = window.innerWidth * 0.8;
    const length = parseInt(plants_container.dataset.length);
    const width = parseInt(plants_container.dataset.width);
    // set the grid scale (i.e. each grid cell is how many mm?
    const grid_cell_mm = parseInt(plants_container.dataset.grid);;
    // work out how many rows and columns we want in the grid
    const grid_rows =  length / grid_cell_mm;
    const grid_cols = width / grid_cell_mm;
    // work out scaling factors
    const mm_per_pixel = width / intViewportWidth;
    const grid_size = intViewportWidth / grid_cols;
    // console.log(grid_rows, grid_cols, mm_per_pixel, grid_size);
    // set container style and dimensions
    plants_container.style.height = `${length / mm_per_pixel}px`;
    plants_container.style.width = `${width / mm_per_pixel}px`;
    // get plant data and iterate
    const plants = JSON.parse(plants_container.dataset.plants);
    plants.forEach((plant) => {
      // create plant div and add it to the plot
      const element = add_plant_to_plot(plant, plants_container, mm_per_pixel);
      // attach the interact plugin to the plant
      init_ineractjs(plant, element, mm_per_pixel, grid_size);
    });
  }
}

export { init_plant_dragging };
