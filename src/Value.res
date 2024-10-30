%raw(`require("./Prism.css")`)

@react.component
let make = (~side, ~handleUpdate) => {
  let (valueState, setValueState) = React.useState(() => "default")
  let (text, setText) = React.useState(() => "")

  let handleInputChange = event => {
    let value = ReactEvent.Form.currentTarget(event)["value"]

    setText(_ => value)
    handleUpdate(value, side)
  }

  <div className="">
    {valueState == "changed"
      ? <span className="changed"> {React.string("24px")} </span>
      : valueState == "default" && valueState != "changed"
      ? <span onClick={ev => setValueState(_ => "focused")}> {React.string("auto")} </span>
      : <input
          className="valueInput" /* value="1000 pt" */
          type_="text"
          value={text}
          onChange={handleInputChange}
          autoFocus={true}
        />}
  </div>
}
