import interact from 'interactjs'


const init_ineractjs=(plant, mm_per_pixel, grid_snap, reverse_xy) => {

  // generate a plant div with a nested thumbnail image
  const plant_div = document.createElement('div');
  const thumbnail = document.createElement('div');

  // set plant div id and css properties
  plant_div.id = `plant-${plant.id}`;
  plant_div.style.width = `${plant.radius_mm * 2 / mm_per_pixel}px`;
  plant_div.style.height = `${plant.radius_mm * 2 / mm_per_pixel}px`;
  plant_div.style.position = 'absolute'
  plant_div.style.border = '1px dashed lightgrey';
  thumbnail.style.height = '100%';
  thumbnail.style.width = '100%';
  thumbnail.style.backgroundImage = `url("${plant.picture_url}")`;
  thumbnail.style.backgroundSize = 'cover';
  thumbnail.style.backgroundPostion = 'center';
  thumbnail.style.borderRadius = '50%';
  plant_div.appendChild(thumbnail)

  // insert the plant div into the plot container
  const plants_container = document.getElementById('plot-container');
  plants_container.appendChild(plant_div)

  var element = plant_div;
  if (reverse_xy) {
    var x = plant.y * mm_per_pixel;
    var y = plant.x * mm_per_pixel;
  } else {
    var x = plant.x * mm_per_pixel;
    var y = plant.y * mm_per_pixel;
  }
  element.style.transform = 'translate(' + x + 'px, ' + y + 'px)';

  interact(element)
    .draggable({
      modifiers: [
        interact.modifiers.snap({
          targets: [
            interact.createSnapGrid({ x: grid_snap, y: grid_snap })
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
      inertia: true
    })
    .on('dragmove', function (event) {
      x += event.dx
      y += event.dy

      event.target.style.transform = 'translate(' + x + 'px, ' + y + 'px)'
    })
}

export { init_ineractjs };
