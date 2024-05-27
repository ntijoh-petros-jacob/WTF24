describe('Check Admin Priveleges', () => {
  it('passes', () => {
    cy.visit('http://localhost:9292/login')
    cy.get('form input[name="username"]').type('petros') 
    cy.get('input[name="password"]').type('petros') 
    cy.get('form').submit() 
    cy.contains('Lägg till product').should('exist')
    cy.visit('http://localhost:9292/products/1')
    cy.contains('input[type="submit"]', 'Delete product from database').should('exist');  })
})