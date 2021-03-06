% Isoparametric Formulation Implementation
% clear memory
clear all

%% Physical parameters
% E: modulus of elasticity
% A: area of cross section
% L: length of bar
E=2e11; A=12.5e-4; L=[0.75,0.75];  

%% Build Elements
% numberElements: number of elements
numberElements=2; 
% numberNodes: number of nodes
numberNodes=3;
% generation of coordinates and connectivities
elementNodes=[1 2;2 3];
nodeCoordinates=[0 0.75 1.5];
% for structure:
   % displacements: displacement vector
   % force : force vector
   % stiffness: stiffness matrix
force=zeros(numberNodes,1);
stiffness=zeros(numberNodes,numberNodes); 
% computation of the system stiffness matrix and force vector
for e=1:numberElements; 
  % elementDof: element degrees of freedom (Dof)
  elementDof=elementNodes(e,:) ;
  detJacobian=L(e)/2;
  invJacobian=1/detJacobian;
  ngp = 2;
  [w,xi]=gauss1d(ngp);
  xc=0.5*(nodeCoordinates(elementDof(1))+nodeCoordinates(elementDof(2)));
  for ip=1:ngp;
      [shape,naturalDerivatives]=shapeFunctionL2(xi(ip)); 
      B=naturalDerivatives*invJacobian;
      stiffness(elementDof,elementDof)=...
      stiffness(elementDof,elementDof)+ B'*B*w(ip)*detJacobian*E*A;
      force(elementDof) = force(elementDof)+...
          20000*shape'*detJacobian*w(ip);
  end
end 
 
%% BCs and solution
% prescribed dofs
prescribedDof = [1,3];
% solution
GDof=numberNodes;
displacements=solution(GDof,prescribedDof,stiffness,force);
% output displacements/reactions
outputDisplacementsReactions(displacements,stiffness, ...
    numberNodes,prescribedDof,force)

%% Stress
stress = zeros(numberElements,1);
for e=1:numberElements;    
    stress(elementNodes(e,:)) = E*B*displacements(elementNodes(e,:));
end

%% Exact solutions
x = 0:0.1:1.5;
displacements_exact=(30000*x-20000*x.^2)/(2*E*A);
stress_exact=(15000-20000*x)/A;

%% plot figures
figure(2)

% Displacements
subplot(1,2,1); hold on;
plot(nodeCoordinates,displacements,'-.sb')
plot(x,displacements_exact,'-r'); hold off;
xlabel('x'); ylabel('displacement, u'); 
legend('FEM','Exact Solution',2);

% Stress
subplot(1,2,2); hold on;
stairs(nodeCoordinates,stress,'-.sb')
plot(x,stress_exact,'-r'); hold off;
xlabel('x'); ylabel('stress, \sigma'); 
legend('FEM','Exact Solution',1);