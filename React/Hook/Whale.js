import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import React from 'react';
import { Link } from 'react-router-dom';
import { Fragment } from 'react/cjs/react.production.min';

export default function Whale() {
  return (
    <Fragment>
       <h2>Whale</h2>
       <button>
  <Link
  to={`/users/` + 3}
  className="btn btn-sm btn-primary m-1"
>
  <FontAwesomeIcon icon="fa-solid fa-square-pen" />
</Link>
</button>
    </Fragment>
 

);
}