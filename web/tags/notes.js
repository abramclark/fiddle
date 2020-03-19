load = ()=>{
    input = $('#input')
    $.getJSON('notes.json', data => window.data = data)
}
