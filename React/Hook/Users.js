import React from "react";
import { useParams } from "react-router-dom";

export default function Users() {
  const { id } = useParams();

  return (
    <div>
      <h1>User id is {id}</h1>
    </div>
  );
}