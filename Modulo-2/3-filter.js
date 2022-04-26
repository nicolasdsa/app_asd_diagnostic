const {obterPessoas} = require('./service');

Array.prototype.meuFilter = function (callback) {
  const list = []
  for(index in this){
    const item = this[index];
    const result = callback(item, index, this);
    if(!result) continue;
    list.push(item);
  }

  return list;
}
async function main(){
  try{
    const{ results } = await obterPessoas('a');
    /*const familiaLars = results.filter((item) => {
      const result = item.name.toLowerCase().indexOf(`lars`) !== -1
      return result 
      // Retorna um booleano
      // Para ver se mantém ou não na lista
      // False => Remove True => Mantém
    })*/

    const familiaLars = results.meuFilter((item, index, lista) => {
      console.log(`index: ${index}`, lista.length);
      return item.name.toLowerCase().indexOf('lars') !== -1});

    const names = familiaLars.map(pessoa => pessoa.name); 

    console.log(names);


  }
  catch(error){
    console.log('DEU RUIM', error);
  }
}

main()