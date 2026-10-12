import { Router } from 'express';
import { validate } from '../../middleware/validate.js';
import { mapsController } from './maps.controller.js';
import { directionsQuery, geocodeQuery, placesQuery, reverseQuery, staticMapQuery } from './maps.schema.js';

export const mapsRouter = Router();

/**
 * @openapi
 * /api/v1/maps/geocode:
 *   get:
 *     tags: [Maps]
 */
mapsRouter.get('/config', mapsController.config);
mapsRouter.get('/geocode', validate({ query: geocodeQuery }), mapsController.geocode);
mapsRouter.get('/reverse', validate({ query: reverseQuery }), mapsController.reverse);
mapsRouter.get('/places', validate({ query: placesQuery }), mapsController.places);
mapsRouter.get('/directions', validate({ query: directionsQuery }), mapsController.directions);
mapsRouter.get('/static', validate({ query: staticMapQuery }), mapsController.staticMap);
